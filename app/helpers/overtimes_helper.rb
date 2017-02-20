module OvertimesHelper
  def sort_jobs jobs
    return jobs.sort_by {|j| j.actual_collection_time }
  end
end