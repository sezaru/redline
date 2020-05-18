defmodule Test.Redline.Pipelines.Pipeline2 do
  alias Test.Redline.Steps

  use Redline, name: :pipeline

  step [{Steps.Step1, name: :step_a}, {Steps.Step1, name: :step_b}]

  step [{Steps.Step4, inputs: [:step_a, :step_b]}, {Steps.Step1WithState, input: :step_a}]
end
