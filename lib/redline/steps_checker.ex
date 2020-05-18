defmodule Redline.StepsChecker do
  alias Redline.Errors.CompilationError

  def check(steps, pipeline) do
    names = []

    _ = Enum.reduce(steps, names, fn step, names -> check(step, names, pipeline) end)

    steps
  end

  defp check({:step, inner_steps}, names, pipeline) when is_list(inner_steps),
    do:
      Enum.map(inner_steps, fn {step, opts} -> do_check(opts, names, {step, pipeline}) end) ++
        names

  defp check({:step, step, opts}, names, pipeline) do
    name = do_check(opts, names, {step, pipeline})

    [name] ++ names
  end

  defp do_check(opts, names, modules) do
    :ok = check_name(opts, names, modules)

    :ok = check_inputs(opts, names, modules)

    %{name: name} = opts

    name
  end

  defp check_name(%{name: name}, names, {step, pipeline}) do
    if name in names, do: raise(CompilationError, "Duplicated name '#{name}' in #{pipeline}.")

    if name == :initial_input do
      raise(CompilationError, "Name cannot be 'initial_input' for step #{step} in #{pipeline}.")
    end

    :ok
  end

  defp check_inputs(%{input: input}, names, modules), do: do_check_input(input, names, modules)

  defp check_inputs(%{inputs: inputs}, names, modules),
    do: Enum.each(inputs, &do_check_input(&1, names, modules))

  defp check_inputs(_, _, _), do: :ok

  defp do_check_input(:initial_input, _, _), do: :ok

  defp do_check_input(input, names, {step, pipeline}) do
    if input not in names,
      do: raise(CompilationError, "Input '#{input}' not found in #{pipeline} for step #{step}.")

    :ok
  end
end
