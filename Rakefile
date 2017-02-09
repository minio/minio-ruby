$REPO_ROOT = File.dirname(__FILE__)

$VERSION = ENV['VERSION'] || File.read(File.join($REPO_ROOT, 'VERSION')).strip

$GEM_NAMES = [
  'minio',
]

$GEM_NAMES.each do |gem_name|
  $LOAD_PATH.unshift(File.join($REPO_ROOT, gem_name, 'lib'))
end

require 'minio'

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end
