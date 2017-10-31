module Kernel

  # Provide easy global read access to the application configuration settings
  def config(config_name = :application)
    SimpleConfig.for(config_name)
  end

end