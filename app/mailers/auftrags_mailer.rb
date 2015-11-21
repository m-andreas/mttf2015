class AuftragsMailer < ActionMailer::Base
  default from: "system@mt-transfair.at"

  def job_confirmation( job, user )
    @user = user
    @job = job
    recipients = ['dispo@mt-transfair.at', 'michael.schneider2@sixt.com']
    recipients << user.email
    recipients.uniq!
    mail(to: recipients, subject: "MT Transfair -  #{I18n.translate("auftragsmail.subject")} #{@job.id}")
  end

  def mass_job_confirmation( jobs, user )
    @user = user
    @jobs = jobs
    recipients = ['dispo@mt-transfair.at', 'michael.schneider2@sixt.com']
    recipients << user.email
    recipients.uniq!
    mail(to: recipients, subject: "MT Transfair - #{I18n.translate("auftragsmail.subject")} #{jobs.length} Fahrten")
  end
end
