zen_desc 'Run database backup',
  team: 'devops',
  safety: :safe,
  keywords: %w[backup database postgres]

task db_backup: :environment do
  system('pg_dump zenhr_production > backup.sql')
end
