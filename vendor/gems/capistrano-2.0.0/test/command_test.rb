require "#{File.dirname(__FILE__)}/utils"
require 'capistrano/command'

class CommandTest < Test::Unit::TestCase
  def test_command_should_open_channels_on_all_sessions
    s1 = mock(:open_channel => nil)
    s2 = mock(:open_channel => nil)
    s3 = mock(:open_channel => nil)
    assert_equal "ls", Capistrano::Command.new("ls", [s1, s2, s3]).command
  end

  def test_command_with_newlines_should_be_properly_escaped
    cmd = Capistrano::Command.new("ls\necho", [mock(:open_channel => nil)])
    assert_equal "ls\\\necho", cmd.command
  end

  def test_command_with_windows_newlines_should_be_properly_escaped
    cmd = Capistrano::Command.new("ls\r\necho", [mock(:open_channel => nil)])
    assert_equal "ls\\\necho", cmd.command
  end

  def test_command_with_env_key_should_have_environment_constructed_and_prepended
    session = setup_for_extracting_channel_action(:on_success) do |ch|
      ch.expects(:exec).with(%(env FOO=bar sh -c "ls"))
    end
    Capistrano::Command.new("ls", [session], :env => { "FOO" => "bar" })
  end

  def test_env_with_symbolic_key_should_be_accepted_as_a_string
    session = setup_for_extracting_channel_action(:on_success) do |ch|
      ch.expects(:exec).with(%(env FOO=bar sh -c "ls"))
    end
    Capistrano::Command.new("ls", [session], :env => { :FOO => "bar" })
  end

  def test_env_as_string_should_be_substituted_in_directly
    session = setup_for_extracting_channel_action(:on_success) do |ch|
      ch.expects(:exec).with(%(env HOWDY=there sh -c "ls"))
    end
    Capistrano::Command.new("ls", [session], :env => "HOWDY=there")
  end

  def test_env_with_symbolic_value_should_be_accepted_as_string
    session = setup_for_extracting_channel_action(:on_success) do |ch|
      ch.expects(:exec).with(%(env FOO=bar sh -c "ls"))
    end
    Capistrano::Command.new("ls", [session], :env => { "FOO" => :bar })
  end

  def test_env_value_should_be_escaped
    session = setup_for_extracting_channel_action(:on_success) do |ch|
      ch.expects(:exec).with(%(env FOO=(\\ \\\"bar\\\"\\ ) sh -c "ls"))
    end
    Capistrano::Command.new("ls", [session], :env => { "FOO" => '( "bar" )' })
  end

  def test_env_with_multiple_keys_should_chain_the_entries_together
    session = setup_for_extracting_channel_action(:on_success) do |ch|
      ch.expects(:exec).with do |command|
        command =~ /^env / &&
        command =~ /\ba=b\b/ &&
        command =~ /\bc=d\b/ &&
        command =~ /\be=f\b/ &&
        command =~ / sh -c "ls"$/
      end
    end
    Capistrano::Command.new("ls", [session], :env => { :a => :b, :c => :d, :e => :f })
  end

  def test_open_channel_should_set_host_key_on_channel
    session = mock(:xserver => server("capistrano"))
    channel = stub_everything

    session.expects(:open_channel).yields(channel)
    channel.expects(:[]=).with(:host, "capistrano")

    Capistrano::Command.new("ls", [session])
  end

  def test_open_channel_should_set_options_key_on_channel
    session = mock(:xserver => server("capistrano"))
    channel = stub_everything

    session.expects(:open_channel).yields(channel)
    channel.expects(:[]=).with(:options, {:data => "here we go"})

    Capistrano::Command.new("ls", [session], :data => "here we go")
  end

  def test_open_channel_should_request_pty
    session = mock(:xserver => server("capistrano"))
    channel = stub_everything

    session.expects(:open_channel).yields(channel)
    channel.expects(:request_pty).with(:want_reply => true)

    Capistrano::Command.new("ls", [session])
  end

  def test_successful_channel_should_send_command
    session = setup_for_extracting_channel_action(:on_success) do |ch|
      ch.expects(:exec).with(%(sh -c "ls"))
    end
    Capistrano::Command.new("ls", [session])
  end

  def test_successful_channel_with_shell_option_should_send_command_via_specified_shell
    session = setup_for_extracting_channel_action(:on_success) do |ch|
      ch.expects(:exec).with(%(/bin/bash -c "ls"))
    end
    Capistrano::Command.new("ls", [session], :shell => "/bin/bash")
  end

  def test_successful_channel_should_send_data_if_data_key_is_present
    session = setup_for_extracting_channel_action(:on_success) do |ch|
      ch.expects(:exec).with(%(sh -c "ls"))
      ch.expects(:send_data).with("here we go")
    end
    Capistrano::Command.new("ls", [session], :data => "here we go")
  end

  def test_unsuccessful_channel_should_close_channel
    session = setup_for_extracting_channel_action(:on_failure) do |ch|
      ch.expects(:close)
    end
    Capistrano::Command.new("ls", [session])
  end

  def test_on_data_should_invoke_callback_as_stdout
    session = setup_for_extracting_channel_action(:on_data, "hello")
    called = false
    Capistrano::Command.new("ls", [session]) do |ch, stream, data|
      called = true
      assert_equal :out, stream
      assert_equal "hello", data
    end
    assert called
  end

  def test_on_extended_data_should_invoke_callback_as_stderr
    session = setup_for_extracting_channel_action(:on_extended_data, 2, "hello")
    called = false
    Capistrano::Command.new("ls", [session]) do |ch, stream, data|
      called = true
      assert_equal :err, stream
      assert_equal "hello", data
    end
    assert called
  end

  def test_on_request_should_record_exit_status
    data = mock(:read_long => 5)
    session = setup_for_extracting_channel_action(:on_request, "exit-status", nil, data) do |ch|
      ch.expects(:[]=).with(:status, 5)
    end
    Capistrano::Command.new("ls", [session])
  end

  def test_on_close_should_set_channel_closed
    session = setup_for_extracting_channel_action(:on_close) do |ch|
      ch.expects(:[]=).with(:closed, true)
    end
    Capistrano::Command.new("ls", [session])
  end

  def test_stop_should_close_all_open_channels
    sessions = [mock("session", :open_channel => new_channel(false)),
                mock("session", :open_channel => new_channel(true)),
                mock("session", :open_channel => new_channel(false))]

    cmd = Capistrano::Command.new("ls", sessions)
    cmd.stop!
  end

  def test_process_should_return_cleanly_if_all_channels_have_zero_exit_status
    sessions = [mock("session", :open_channel => new_channel(true, 0)),
                mock("session", :open_channel => new_channel(true, 0)),
                mock("session", :open_channel => new_channel(true, 0))]
    cmd = Capistrano::Command.new("ls", sessions)
    assert_nothing_raised { cmd.process! }
  end

  def test_process_should_raise_error_if_any_channel_has_non_zero_exit_status
    sessions = [mock("session", :open_channel => new_channel(true, 0)),
                mock("session", :open_channel => new_channel(true, 0)),
                mock("session", :open_channel => new_channel(true, 1))]
    cmd = Capistrano::Command.new("ls", sessions)
    assert_raises(Capistrano::CommandError) { cmd.process! }
  end

  def test_command_error_should_include_accessor_with_host_array
    sessions = [mock("session", :open_channel => new_channel(true, 0)),
                mock("session", :open_channel => new_channel(true, 0)),
                mock("session", :open_channel => new_channel(true, 1))]
    cmd = Capistrano::Command.new("ls", sessions)

    begin
      cmd.process!
      flunk "expected an exception to be raised"
    rescue Capistrano::CommandError => e
      assert e.respond_to?(:hosts)
      assert_equal %w(capistrano), e.hosts.map { |h| h.to_s }
    end
  end

  def test_process_should_loop_until_all_channels_are_closed
    new_channel = Proc.new do |times|
      ch = mock("channel")
      returns = [false] * (times-1)
      ch.stubs(:[]).with(:closed).returns(*(returns + [true]))
      con = mock("connection")
      con.expects(:process).with(true).times(times-1)
      ch.expects(:connection).times(times-1).returns(con)
      ch.expects(:[]).with(:status).returns(0)
      ch
    end

    sessions = [mock("session", :open_channel => new_channel[5]),
                mock("session", :open_channel => new_channel[10]),
                mock("session", :open_channel => new_channel[7])]
    cmd = Capistrano::Command.new("ls", sessions)
    assert_nothing_raised { cmd.process! }
  end

  def test_process_should_ping_all_connections_each_second
    now = Time.now

    new_channel = Proc.new do
      ch = mock("channel")
      ch.stubs(:now => now)
      def ch.[](key)
        case key
        when :status then 0
        when :closed then Time.now - now < 1.1 ? false : true
        else raise "unknown key: #{key}"
        end
      end
      con = mock("connection")
      con.stubs(:process)
      con.expects(:ping!)
      ch.stubs(:connection).returns(con)
      ch
    end

    sessions = [mock("session", :open_channel => new_channel[]),
                mock("session", :open_channel => new_channel[]),
                mock("session", :open_channel => new_channel[])]
    cmd = Capistrano::Command.new("ls", sessions)
    assert_nothing_raised { cmd.process! }
  end

  def test_process_should_instantiate_command_and_process!
    cmd = mock("command", :process! => nil)
    Capistrano::Command.expects(:new).with("ls -l", %w(a b c), {:foo => "bar"}).yields(:command).returns(cmd)
    parameter = nil
    Capistrano::Command.process("ls -l", %w(a b c), :foo => "bar") { |cmd| parameter = cmd }
    assert_equal :command, parameter
  end

  def test_process_with_host_placeholder_should_substitute_placeholder_with_each_host
    session = setup_for_extracting_channel_action(:on_success) do |ch|
      ch.expects(:exec).with(%(sh -c "echo capistrano"))
    end
    Capistrano::Command.new("echo $CAPISTRANO:HOST$", [session])
  end

  def test_process_with_unknown_placeholder_should_not_replace_placeholder
    session = setup_for_extracting_channel_action(:on_success) do |ch|
      ch.expects(:exec).with(%(sh -c "echo \\$CAPISTRANO:OTHER\\$"))
    end
    Capistrano::Command.new("echo $CAPISTRANO:OTHER$", [session])
  end

  private

    def new_channel(closed, status=nil)
      ch = mock("channel")
      ch.expects(:[]).with(:closed).returns(closed)
      ch.expects(:[]).with(:status).returns(status) if status
      ch.expects(:close) unless closed
      ch.stubs(:[]).with(:host).returns("capistrano")
      ch.stubs(:[]).with(:server).returns(server("capistrano"))
      ch
    end

    def setup_for_extracting_channel_action(action, *args)
      s = server("capistrano")
      session = mock("session", :xserver => s)

      channel = stub_everything
      session.expects(:open_channel).yields(channel)

      ch = mock
      ch.stubs(:[]).with(:server).returns(s)
      ch.stubs(:[]).with(:host).returns(s.host)
      channel.expects(action).yields(ch, *args)

      yield ch if block_given?

      session
    end
end
