defmodule Test.Redline.Steps.Step1WithError do
  use Redline.Step, name: :step_1_with_error

  @impl Redline.Step
  def run(_input, state), do: {{:error, :some_reason}, state}
end
