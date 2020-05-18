defmodule Test.Redline.Steps.Step2 do
  use Redline.Step, name: :step_2, input: :step_1

  @impl Redline.Step
  def run(step_1, state), do: {step_1 + 2, state}
end
