namespace :approvals do
  # @zen team: hr-platform
  # @zen safety: caution
  # @zen keywords: sync, permissions
  desc 'Synchronize approval permissions'
  task :sync_permissions, [:days_ago] => :environment do |_, args|
    days_ago = args[:days_ago].to_i.nonzero? || 1
    ApprovalSynchronizer.new(since: days_ago.days.ago).call
  end

  desc 'Skip nonresponsive approvers'
  task skip_nonresponsive: :environment do
    Approval.pending.each(&:skip_if_stale)
  end
end
