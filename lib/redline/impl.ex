defmodule Redline.Impl do
  alias Redline.State
  alias Redline.Impl.{Parallel, MultiInput, SingleInput}

  def run(inputs, steps),
    do: State.new() |> run_first_step(inputs, steps)

  def run(inputs, state, steps),
    do: state |> State.reset_results() |> run_first_step(inputs, steps)

  defp run_first_step(state, _, []), do: {nil, state}

  defp run_first_step(state, inputs, [step | steps]) do
    state
    |> insert_inputs(inputs)
    |> run_step(step)
    |> run_next_step(steps)
  end

  defp run_next_step({:stop, state}, _), do: {:stop, state}
  defp run_next_step({{:error, reason}, state}, _), do: {{:error, reason}, state}

  defp run_next_step({last, state}, []), do: {last, state}

  defp run_next_step({_, state}, [step | steps]) do
    state
    |> run_step(step)
    |> run_next_step(steps)
  end

  defp run_step(state, {:step, step}) when is_list(step), do: Parallel.run_step(state, step)
  defp run_step(state, {:step, _, %{inputs: _}} = step), do: MultiInput.run_step(state, step)
  defp run_step(state, step), do: SingleInput.run_step(state, step)

  defp insert_inputs(state, {inputs, names}) when is_list(names) do
    inputs
    |> Tuple.to_list()
    |> Enum.zip(names)
    |> Enum.reduce(state, fn {input, name}, state -> State.update_results(state, name, input) end)
  end

  defp insert_inputs(state, {input, name}), do: State.update_results(state, name, input)
end
