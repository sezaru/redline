defmodule Redline.Impl.SingleInput do
  alias Redline.State

  def run_step(state, input, step) do
    {_, module, %{name: name}} = step

    {result, step_state} = run_step(input, name, module, state)

    state = State.update_step(state, name, result, step_state)

    {result, state}
  end

  def run_step(state, step) do
    {_, module, %{name: name, input: input}} = step

    {result, step_state} = state |> State.get_result!(input) |> run_step(name, module, state)

    state = State.update_step(state, name, result, step_state)

    {result, state}
  end

  def run_step(input, name, module, state) do
    step_state = State.get_step_state(state, name, module)

    module.run(input, step_state)
  end
end
