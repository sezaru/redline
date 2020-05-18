defmodule Test.Redline.Steps.Step1WithState do
  use Redline.Step, name: :step_1, state: %{last: nil}

  @impl Redline.Step
  def run(input, %{last: nil}) do
    {:stop, %{last: input}}
  end

  def run(input, %{last: last}), do: {input + last, %{last: input}}
end
