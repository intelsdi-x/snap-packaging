require "spec_helper"

case os[:family]
when 'darwin'
else
  describe command("snap plugin list") do
    its(:stdout) { should match /NAME/ }
    its(:exit_status) { should eq 0 }
  end

  require 'pry'
  binding.pry
  %w[apache, foo, bar, ex ].each do |plugin|
    describe command("snapctl plugin load #{plugin}") do
      its(:stdout) { should match /loaded/ }
      its(:exit_status) { should eq 0 }
    end

    describe command("snapctl plugin unload #{plugin}") do
      its(:stdout) { should match /loaded/ }
      its(:exit_status) { should eq 0 }
    end
  end
end
