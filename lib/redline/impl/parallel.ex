defmodule Redline.Impl.Parallel do
  alias Redline.State
  alias Redline.Impl.{SingleInput, MultiInput}

  def run_step(state, input, step) when is_list(step) do
    results =
      step
      |> Enum.reduce(ParallelTask.new(), fn inner_step, parallel_task ->
        run_inner_step(inner_step, input, state, parallel_task)
      end)
      |> ParallelTask.perform()

    state = Enum.reduce(results, state, &update_state/2)
    results = extract_results(results)

    {results, state}
  end

  def run_step(state, step) when is_list(step) do
    results =
      step
      |> Enum.reduce(ParallelTask.new(), fn inner_step, parallel_task ->
        run_inner_step(inner_step, state, parallel_task)
      end)
      |> ParallelTask.perform()

    state = Enum.reduce(results, state, &update_state/2)
    results = extract_results(results)

    {results, state}
  end

  defp run_inner_step({module, %{name: name}}, input, state, parallel_task) do
    ParallelTask.add(parallel_task, name, fn ->
      SingleInput.run_step(input, name, module, state)
    end)
  end

  defp run_inner_step({module, %{name: name, inputs: inputs}}, state, parallel_task) do
    ParallelTask.add(parallel_task, name, fn ->
      inputs = State.get_results!(state, inputs)

      MultiInput.run_step(inputs, name, module, state)
    end)
  end

  defp run_inner_step({module, %{name: name, input: input}}, state, parallel_task) do
    ParallelTask.add(parallel_task, name, fn ->
      input = State.get_result!(state, input)

      SingleInput.run_step(input, name, module, state)
    end)
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
