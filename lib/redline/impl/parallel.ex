defmodule Redline.Impl.Parallel do
  alias Redline.State
  alias Redline.Impl.{SingleInput, MultiInput}

  def run_step(state, step) when is_list(step) do
    results =
      step
      |> Enum.map(&Task.async(fn -> run_inner_step(&1, state) end))
      |> Enum.map(&Task.await(&1, :infinity))

    state = Enum.reduce(results, state, &update_state/2)
    results = extract_results(results) |> IO.inspect()

    {results, state}
  end

  defp run_inner_step({module, %{name: name, inputs: inputs}}, state) do
    result = state |> State.get_results!(inputs) |> MultiInput.run_step(name, module, state)

    {name, result}
  end

  defp run_inner_step({module, %{name: name, input: input}}, state) do
    result = state |> State.get_result!(input) |> SingleInput.run_step(name, module, state)

    {name, result}
  end

  defp run_inner_step({module, %{name: name}}, state) do
    result =
      state |> State.get_result!(:initial_input) |> SingleInput.run_step(name, module, state)

    {name, result}
  end

  defp update_state({name, {result, step_state}}, state),
    do: State.update_step(state, name, result, step_state)

  defp extract_results(results),
    do:
      results
      |> Enum.map(fn {_, {result, _}} -> result end)
      |> check_for_error()
      |> check_for_stop()

  defp check_for_error(results) when is_list(results) do
    case Enum.find(results, fn v -> match?({:error, _}, v) end) do
      nil -> results
      error -> error
    end
  end

  defp check_for_stop(results) when is_list(results) do
    case Enum.find(results, fn v -> v == :stop end) do
      nil -> results
      stop -> stop
    end
  end

  defp check_for_stop(error), do: error
end
