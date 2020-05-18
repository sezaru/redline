defmodule Redline.StepsChecker do
  alias Redline.Errors.CompilationError

  def check(steps, pipeline_inputs, pipeline) do
    names = initialize_names(pipeline_inputs)

    _ = Enum.reduce(steps, names, fn step, names -> do_check(step, names, pipeline) end)

    steps
  end

  defp do_check({:step, inner_steps}, names, pipeline) when is_list(inner_steps) do
    Enum.map(inner_steps, fn {step, opts} -> do_check(opts, names, {step, pipeline}) end) ++ names
  end

  defp do_check({:step, step, opts}, names, pipeline) do
    name = do_check(opts, names, {step, pipeline})

    [name] ++ names
  end

  defp do_check(opts, names, modules) do
    :ok = check_name(opts, names, modules)

    :ok = check_inputs(opts, names, modules)

    %{name: name} = opts

    name
  end

  defp check_name(%{name: name}, names, {_, pipeline}) do
    if name in names, do: raise(CompilationError, "Duplicated name '#{name}' in #{pipeline}.")

    :ok
  end

  defp check_inputs(%{input: input}, names, modules), do: do_check_input(input, names, modules)

  defp check_inputs(%{inputs: inputs}, names, modules),
    do: Enum.each(inputs, &do_check_input(&1, names, modules))

  defp check_inputs(_, names, modules), do: do_check_input(:initial_input, names, modules)

  defp do_check_input(input, names, {step, pipeline}) do
    if input not in names,
      do: raise(CompilationError, "Input '#{input}' not found in #{pipeline} for step #{step}.")

    :ok
  end

  defp initialize_names(pipeline_inputs) when is_list(pipeline_inputs), do: pipeline_inputs
  defp initialize_names(pipeline_input), do: [pipeline_input]
end
