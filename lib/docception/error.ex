defmodule Docception.Error do
  @moduledoc """
  An error during Docception.
  """
  defexception [:message]

  @impl true
  def exception(message) do
    %__MODULE__{message: message}
  end
end
