defmodule Redline.Impl.MultiInput do
  alias Redline.State

  def run_step(state, step) do
    {_, module, %{name: name, inputs: inputs}} = step

    {result, step_state} = state |> State.get_results!(inputs) |> run_step(name, module, state)

    state = State.update_step(state, name, result, step_state)

    {result, state}
  end

  def run_step(inputs, name, module, state) do
    step_state = State.get_step_state(state, name, module)

    module.run(inputs, step_state)
  end
end
