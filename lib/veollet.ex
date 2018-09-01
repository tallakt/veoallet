defmodule Veollet do
  @moduledoc """
  Simplest wallet for Amoveo Blockchain
  """

  def hex_to_bin(hex_str) do
    Regex.scan(~r(..), hex_str)
    |> Enum.map(fn [x] -> String.to_integer(x, 16) end)
    |> :binary.list_to_bin()
  end

  defp public_key(private_key) do
    {pub, _} = :crypto.generate_key(:ecdh, :crypto.ec_curve(:secp256k1), private_key)
    Base.encode64(pub)
  end

  defp greeting() do
    IO.puts("This is a really simple wallet software for Amoveo that lets you")
    IO.puts("sign transactions without giving your private keys to a web page.")
    IO.puts("To verify that your keys are safe, simply read the script file")
    IO.puts("before you run it.")
    IO.puts("")
  end

  def ask_for_private_key() do
    IO.gets("Please enter you private key: ")
    |> String.trim()
    |> hex_to_bin
  end

  defp get_private_key_from_args_file([filename | _]) do
    case File.read(Path.expand(filename)) do
      {:ok, contents} ->
        hex_to_bin(contents)

      _ ->
        nil
    end
  end

  defp get_private_key_from_args_file(_), do: nil

  def sign_tx(tx, private_key) do
    opts = [private_key, :crypto.ec_curve(:secp256k1)]
    signature = :crypto.sign(:ecdsa, :sha256, serialize(tx), opts)
    {:signed, tx, Base.encode64(signature), []}
  end

  def serialize(data) when is_binary(data), do: <<0, byte_size(data)::32, data::binary>>

  def serialize(list) when is_list(list) do
    inner = for x <- list, do: serialize(x), into: ""
    <<1, byte_size(inner)::32, inner::binary>>
  end

  def serialize(tup) when is_tuple(tup) do
    list = Tuple.to_list(tup)
    inner = for x <- list, do: serialize(x), into: ""
    <<2, byte_size(inner)::32, inner::binary>>
  end

  def serialize(i) when is_integer(i), do: <<3, i::512>>

  def serialize(a) when is_atom(a) do
    data = Atom.to_string(a)
    <<4, byte_size(data)::32, data::binary>>
  end

  defp web_to_erlang_data(data)

  # its a list
  defp web_to_erlang_data([-6 | t]), do: Enum.map(t, &web_to_erlang_data/1)

  # its a tuple
  defp web_to_erlang_data([-7 | t]) do
    t
    |> Enum.map(&web_to_erlang_data/1)
    |> List.to_tuple()
  end

  # record tuple
  defp web_to_erlang_data([string | t]) when is_binary(string) do
    elements = Enum.map(t, &web_to_erlang_data/1)
    List.to_tuple([String.to_atom(string) | elements])
  end

  defp web_to_erlang_data(data), do: data

  defp erlang_to_web_data(data)

  defp erlang_to_web_data(list) when is_list(list) do
    [-6 | Enum.map(list, &erlang_to_web_data/1)]
  end

  defp erlang_to_web_data(tuple) when is_tuple(tuple) do
    erlang_to_web_data_helper(Tuple.to_list(tuple))
  end

  defp erlang_to_web_data(data), do: data

  defp erlang_to_web_data_helper([atom | t]) when is_atom(atom) do
    [Atom.to_string(atom) | Enum.map(t, &erlang_to_web_data/1)]
  end

  defp erlang_to_web_data_helper(list) do
    [-7 | Enum.map(list, &erlang_to_web_data/1)]
  end

  def main(args \\ []) do
    greeting()

    private_key = get_private_key_from_args_file(args) || ask_for_private_key()

    IO.puts("Your public key is: #{public_key(private_key)}")
    IO.puts("")

    signed =
      IO.gets("Please enter the transaction to sign: ")
      |> String.trim()
      |> Poison.decode!()
      |> web_to_erlang_data
      |> sign_tx(private_key)

    json_for_web =
      signed
      |> erlang_to_web_data
      |> Poison.encode!()

    IO.puts("")
    IO.puts("The signed transaction is:")
    IO.puts(json_for_web)
    IO.puts("")
  end
end
