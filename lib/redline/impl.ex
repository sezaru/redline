defmodule Redline.Impl do
  alias Redline.State
  alias Redline.Impl.{Parallel, MultiInput, SingleInput}

  def run(input, steps), do: State.new() |> run_first_step(input, steps)

  def run(input, state, steps),
    do: state |> State.reset_results() |> run_first_step(input, steps)

  defp run_first_step(state, _, []), do: {nil, state}

  defp run_first_step(state, initial_input, [step | steps]) do
    state
    |> run_step(initial_input, step)
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

  defp run_step(state, input, {:step, step}) when is_list(step),
    do: Parallel.run_step(state, input, step)

  defp run_step(state, input, step),
    do: SingleInput.run_step(state, input, step)

  defp run_step(state, {:step, step}) when is_list(step), do: Parallel.run_step(state, step)
  defp run_step(state, {:step, _, %{inputs: _}} = step), do: MultiInput.run_step(state, step)
  defp run_step(state, {:step, _, %{input: _}} = step), do: SingleInput.run_step(state, step)
end
