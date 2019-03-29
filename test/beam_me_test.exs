defmodule BeamMeTest do
  use ExUnit.Case

  test "can convert a string into a beam" do
    random_string = "4"
    source = "testfile.md"

    # build the binary
    assert {:ok, binary} = :beam_me.string_to_beam(MyModule, random_string, source)

    # nothing loaded yet
    assert_raise UndefinedFunctionError, fn ->
      MyModule.module_info(:module)
    end

    # we can indeed load this
    assert {:module, MyModule} == :code.load_binary(MyModule, 'i made this up', binary)

    # we can call auto-generated functions
    assert MyModule == MyModule.module_info(:module)
    assert MyModule == MyModule.__info__(:module)
    assert source == MyModule.__info__(:compile)[:source]

    # we have a 'Docs' chunk
    assert {:ok, _, chunks} = :beam_lib.all_chunks(binary)
    chunks = Enum.into(chunks, %{})
    assert docs_term = chunks['Docs']

    # We can decode that chunk
    assert {:docs_v1, line, :elixir, mime, module_doc, module_doc_meta, stuff} =
      :erlang.binary_to_term(docs_term)

    # And in module_doc, we find our well-known random string
    assert random_string == module_doc["en"]
  end
end
