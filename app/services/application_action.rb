class ApplicationAction < ApplicationService
  def self.execute!(*args, &block)
    new(*args, &block).execute!
  end

  protected

  def execute!
    raise NotImplementedError
  end
end
