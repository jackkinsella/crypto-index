module Recordings
  extend ActiveSupport::Concern

  def stub_request_with_recording(method, url)
    stub_request(method, url).to_return(
      body: File.read(path_to_recording(url))
    )
  rescue Errno::ENOENT
    WebMock.disable! && generate_recording(url) && WebMock.enable!

    puts Rainbow('[REC]').bold.cyan + ' ' + <<~TEXT
      The recording for #{url} has been generated. Resuming...
    TEXT
  end

  private

  def generate_recording(url)
    File.open(path_to_recording(url), 'w') { |file|
      file.write(open(url).read)
    }
  end

  def path_to_recording(url)
    name = url.gsub(/https?:\/{2}/, '').gsub(/\/$/, '').tr('/', '_')
    name = "#{name[0...99]}_#{Digest::MD5.hexdigest(name)}" if name.size > 132
    "#{Rails.root}/spec/recordings/#{name}.rec"
  end
end
