defmodule Test.Redline.Steps.Step1 do
  use Redline.Step, name: :step_1

  @impl Redline.Step
  def run(input, state), do: {input + 1, state}
end
