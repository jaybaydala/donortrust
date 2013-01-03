class Search
  MAX_ATTEMPTS = 5

  # this should help with the "index not prerea"d errors
  # the error happens when somebody searches the moment that sphinx is rotating
  # the indexes, which happens very quickly. This gives it a chance to finish
  # and still return results instead of a 500 error - see https://gist.github.com/1818244
  def self.with_retries
    attempt = 0
    begin
      yield
    rescue ThinkingSphinx::SphinxError
      # We over-eagerly rescue all Sphinx errors. But since we re-raise them
      # if they still fail after a few attempts, we don't hide anything.
      attempt += 1
      if attempt > MAX_ATTEMPTS
        raise
      else
        retry
      end
    end
  end
end
