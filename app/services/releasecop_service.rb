class ReleasecopService
  attr_accessor :project

  LOG_LINE_EXPR = /^(?<sha>[0-9a-f]+) (?<date>[0-9\-]+) (?<message>.*) \((?<name>.*), (?<email>.*)\)\w*$/ # %h %ad %s (%an, %ae)

  def self.parsed_log_line(line)
    line.match(LOG_LINE_EXPR)&.named_captures || {}
  end

  def initialize(project)
    @project = project
  end

  def perform_comparison
    Dir.mktmpdir(['releasecop', project.name]) do |dir|
      checker = Releasecop::Checker.new(
        project.name,
        project.stages.order(position: :asc).map { |s| build_manifest_item(s) },
        dir
      )
      ResultWrapper.new(checker) # build comparisons
    end
  end

  class ResultWrapper
    attr_accessor :result, :error

    def initialize(checker)
      begin
        @result = checker.check
      rescue => ex
        self.error = ex
      end
    end

    def comparisons
      @result&.comparisons || []
    end
  end

  private

  def construct_git(stage)
    if stage.profile&.basic_username || stage.profile&.basic_password
      uri = URI(stage.git_remote)
      uri.user = stage.profile&.basic_username
      uri.password = stage.profile&.basic_password
      uri.to_s
    else
      stage.git_remote
    end
  end

  def build_manifest_item(stage)
    {
      'name' => stage.name,
      'git' => construct_git(stage),
      'tag_pattern' => stage.tag_pattern.presence,
      'branch' => stage.branch.presence,
      'hokusai' => stage.hokusai.presence,
      'aws_access_key_id' => stage.profile&.environment&.fetch('AWS_ACCESS_KEY_ID'),
      'aws_secret_access_key' => stage.profile&.environment&.fetch('AWS_SECRET_ACCESS_KEY')
    }
  end

end
