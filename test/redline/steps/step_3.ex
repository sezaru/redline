defmodule Test.Redline.Steps.Step3 do
  use Redline.Step, name: :step_3, input: :step_1

  @impl Redline.Step
  def run(step_1, state), do: {step_1 + 3, state}
end
