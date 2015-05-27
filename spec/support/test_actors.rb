class TestActor < Transactor::Actor
  attr_reader :performed

  def perform
    @performed = true
  end

  def rollback
    @performed = false
  end
end

class FailingActor < Transactor::Actor
  attr_reader :rolled_back

  def perform
    raise "FAIL"
  end

  def rollback
    @rolled_back = true
  end
end

class BlockActor < Transactor::Actor
  def perform(&block)
    instance_eval &block if block_given?
  end

  def rollback(&block)
    instance_eval &block if block_given?
  end
end
