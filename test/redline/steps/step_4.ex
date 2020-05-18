defmodule Test.Redline.Steps.Step4 do
  use Redline.Step, name: :step_4, inputs: [:step_2, :step_3]

  @impl Redline.Step
  def run({step_2, step_3}, state), do: {step_2 + step_3, state}
end
