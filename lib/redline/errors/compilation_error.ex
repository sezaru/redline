defmodule Redline.Errors.CompilationError do
  defexception [:reason]

  def exception(reason), do: struct!(__MODULE__, reason: reason)

  def message(%{reason: reason}), do: reason
end
