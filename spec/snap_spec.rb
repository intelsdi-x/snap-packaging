require "spec_helper"

describe file("/opt/snap/bin/snaptel") do
  it { should be_file }
  it { should be_executable }
end

describe file("/opt/snap/sbin/snapteld") do
  it { should be_file }
  it { should be_executable }
end

describe file("/usr/local/bin/snapd") do
  it { should be_symlink }
end

describe file("/usr/local/bin/snapctl") do
  it { should be_symlink }
end

describe file("/usr/local/bin/snaptel") do
  it { should be_symlink }
end

describe file("/usr/local/sbin/snapteld") do
  it { should be_symlink }
end

describe command("/opt/snap/sbin/snapteld help") do
  its(:stdout) { should match /snap(tel|)d - The open telemetry framework/ }
end

describe command("/opt/snap/bin/snaptel") do
  its(:stdout) { should match /snap(tel|ctl) - The open telemetry framework/ }
end

describe command("/opt/snap/bin/snapctl ") do
  its(:stderr) { should match /This command is deprecated/ }
end

describe command("/opt/snap/bin/snapd help") do
  its(:stderr) { should match /This command is deprecated/ }
end

case os[:family]
when 'darwin'
  describe package("com.intel.pkg.snap-telemetry") do
    it { should be_installed.by("pkgutil") }
  end

else
  describe package("snap-telemetry") do
    it { should be_installed }
  end

  describe command("ldd /opt/snap/sbin/snapteld") do
    its(:stdout) { should match /not a dynamic executable/ }
  end

  describe service("snap-telemetry") do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8181) do
    it { should be_listening }
  end

  # NOTE: disable this test for now
  # describe file("/var/log/snap/snapteld.log") do
  #   it { should exist }
  # end
end
