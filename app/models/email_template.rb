class EmailTemplate < ActiveRecord::Base
  enum recipients: {
    accepted_mentees: 0,
    rejected_mentees: 1,
    accepted_mentors: 2,
    mentees_running_late: 3,
    missing_mentors: 4,
    missing_mentees: 5,
    passed_mentees: 8,
    failed_mentees: 9,
    mentors_on_waiting_list: 10,
    rejected_mentors: 11,
    mentees_on_waiting_list: 12,
    unregistered_mentees: 13,
    unregistered_mentors: 14,
    mentor_midterm_evaluation: 15,
    mentee_midterm_evaluation: 16,
    mentees_missing_on_website: 17,
    mentors_missing_on_website: 18,
    final_mentees: 19,
    final_mentors: 20,
    final_passing_mentors: 21,
    final_failed_mentors: 22,
    final_passing_mentees: 23,
    final_failed_mentees: 24
  }

  validates :subject, :body, :recipients, presence: true
  validates :recipients, inclusion: { in: EmailTemplate.recipients.keys }

  def self.search params
    where("subject ILIKE ?", "%#{params[:subject]}%")
  end

  def users
    case recipients.to_sym
    when :accepted_mentees
      User.mentee.where(results_send_at: nil)
    when :accepted_mentors
      User.mentor.where(results_send_at: nil)
    when :mentors_on_waiting_list
      MentorApplication.waiting_list.where(results_send_at: nil)
    when :rejected_mentors
      MentorApplication.all_rejected_candidates
    when :rejected_mentees
      MenteeApplication.all_rejected_candidates
    when :mentees_on_waiting_list
      MenteeApplication.waiting_list.where(results_send_at: nil)
    when :unregistered_mentees
      User.mentee.where.not(registration_token: nil)
    when :unregistered_mentors
      User.mentor.where.not(registration_token: nil)
    when :mentor_midterm_evaluation
      User.mentor.joins(:mentor_project)
    when :mentee_midterm_evaluation
      User.mentee.joins(:mentee_project)
    when :mentees_missing_on_website
      User.mentees_missing_on_website
    when :mentors_missing_on_website
      User.mentors_missing_on_website
    when :final_mentees
      User.mentee.joins(:mentee_project)
    when :final_mentors
      User.mentor.joins(:mentor_project)
    when :final_passing_mentors
      Project.with_passing_mentors.map{|p| p.mentor}
    when :final_failed_mentors
      Project.with_failed_mentors.map{|p| p.mentor}
    when :final_passing_mentees
      Project.with_passing_mentees.map{|p| p.mentee}
    when :final_failed_mentees
      Project.with_failed_mentees.map{|p| p.mentee}
    else
      User.none
    end
  end
end
