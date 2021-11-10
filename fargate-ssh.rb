require 'aws-sdk-ecs'
DEFAULT_COMMAND = "/bin/sh"
DEFAULT_CONTAINER = "app"

container = ARGV[1] || DEFAULT_CONTAINER
command = ARGV[2] || DEFAULT_COMMAND

client = Aws::ECS::Client.new

## クラスターの選択
list_clusters_resp = client.list_clusters
cluster_arns = list_clusters_resp.cluster_arns

puts '--- Your Account\'s clusters are here. --- '
cluster_arns.each.with_index do |name, i|
  puts "#{i + 1}: #{name}"
end

print 'Choose Cluster: '
cluster_id = gets.chomp.to_i
if cluster_id < 0 || cluster_id > cluster_arns.size
  raise "Invalid arguments: #{cluster_id}"
end
chosen_cluster = cluster_arns[cluster_id - 1]

## サービスの選択
list_services_resp = client.list_services(cluster: chosen_cluster)
service_arns = list_services_resp.service_arns

puts "--- #{chosen_cluster}'s services are here. --- "
service_arns.each.with_index do |name, i|
  puts "#{i + 1}: #{name}"
end

print 'Choose Service: '
service_id = gets.chomp.to_i
if service_id < 0 || service_id > service_arns.size
  raise "Invalid arguments: #{service_id}"
end
chosen_service = service_arns[service_id - 1]

## タスクの選択
list_tasks_resp = client.list_tasks(cluster: chosen_cluster, service_name: chosen_service)
task_arns = list_tasks_resp.task_arns
puts "--- #{chosen_cluster}/#{chosen_service}'s tasks are here. --- "
task_arns.each.with_index do |name, i|
  puts "#{i + 1}: #{name}"
end
print 'Choose Task: '
task_id = gets.chomp.to_i
if task_id < 0 || task_id > task_arns.size
  raise "Invalid arguments: #{task_id}"
end
chosen_task = task_arns[task_id - 1]

puts 'You can exec bellow commands:'
puts "aws ecs execute-command --cluster \"#{chosen_cluster}\" --task \"#{chosen_task}\" --interactive --container #{container} --command \"#{command}\""

# TODO: ruby 内で interactive な shell を実行するのはどうすればいいんだろう?
# ## execute-command 確認と実行
# puts "I will exec-command with bellow options."
# puts "cluster: #{chosen_cluster}"
# puts "service: #{chosen_service}"
# puts "task: #{chosen_task}"
# puts "container: #{container}"
# puts "COMMAND: #{command}"
#
# print 'Sure? (Y/n): '
# sure = gets.chomp
#
# if sure == 'Y' || sure == 'y'
#   client.execute_command({
#     cluster: chosen_cluster,
#     container: container,
#     command: command,
#     interactive: true,
#     task: chosen_task,
#   })
# else
#   puts 'Abort!'
# end
