class ErrorMailer < ActionMailer::Base
  def snapshot(exception, trace, session, params, env, sent_on = Time.now)
    content_type "text/html" 
    @recipients         = 'tim@pivotib.com,desiree.mckee@ideaca.com,Stephen.Smith@ideaca.com'
    @from               = 'CF Error Mailer <errors@christmasfuture.org>'
    @subject            = "[Error] exception in #{env['REQUEST_URI']}" 
    @sent_on            = sent_on
    @body["exception"]  = exception
    @body["trace"]      = trace
    @body["session"]    = session
    @body["params"]     = params
    @body["env"]        = env
  end
end
