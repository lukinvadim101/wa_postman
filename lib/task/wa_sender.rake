# require 'wa_sender'

desc 'WA Posts Manager'
task :send, [:path] do |_t, args|
  options = {}
  opts = OptionParser.new

  opts.on('-p', '--path ARG', String) { |path| options[:path] = path }
  opts.on('-t', '--term ARG', String) { |term| options[:term] = term }

  args = opts.order!(ARGV) {}
  opts.parse!(args)

  csv_data = CSV_reader.new(options[:path]).csv_data
  store = Store.new(csv_data).data
  Sender.new(store).execute(options[:term])
end

# rake send -- --path data/exm.csv --term advance
# rake send -- --path data/exm.csv --term due
# rake send -- --path data/exm.csv --term overdue
