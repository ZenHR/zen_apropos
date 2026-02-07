namespace :indexer do
  # @zen team: search
  # @zen safety: safe
  # @zen keywords: elasticsearch, reindex
  desc 'Reindex all employees'
  task employees: :environment do
    Employee.reindex
  end

  desc 'Reindex all departments'
  task departments: :environment do
    Department.reindex
  end

  # @zen team: search
  # @zen safety: destructive
  desc 'Reset all indices'
  task reset_all: :environment do
    Searchkick.models.each do |model|
      model.searchkick_index.delete if model.searchkick_index.exists?
      model.reindex(import: false)
    end
  end
end
