# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :test do
  watch(%r{^lib/(.+)\.rb$})   { "test" }
  watch(%r{^test/test_.+\.rb$})   { "test" }
  watch('test/test_helper.rb')  { "test" }
end
