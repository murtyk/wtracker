# frozen_string_literal: true

class SpecListener
  def start(_notification)
    puts '**Running before the entire suite**'
  end

  def example_started(_notification)
    puts '**Running before each example**'
  end

  # for profiling specs
  def example_passed(n)
    # puts n.example.full_description + ":   " + n.example.execution_result.run_time.to_s
  end

  def example_failed(_notification)
    puts '**This example failed :(**'
  end
end
