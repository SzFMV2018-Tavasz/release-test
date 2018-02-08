require 'rest-client'
require 'json'

def create_release
    release_msg = "Nightly build based on #{$commit} at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    response = JSON.parse(RestClient.post "https://api.github.com/repos/#{$owner}/#{$repo}/releases?access_token=#{$GH_TOKEN}", {tag_name: $tag, target_commitish: "master", name: "nightly", body: release_msg, draft: false, prerelease: true}.to_json)
    
    RestClient::Request.execute(method: :post, url: response["upload_url"][0..-14] + "?name='#{$filename_label}'&label=Single runnable jar&access_token=#{$GH_TOKEN}", payload: File.new($filename, "rb"), headers: {'Content-Type': 'application/zip'})
    
    puts "release added"
end

# set variables
$owner = "SzFMV2018-Tavasz"
$repo = "release-test"
$tag = "nightly"
$filename = ENV["HOME"] + "/master/target/release-test.jar"
$filename_label="release-test.jar"
$GH_TOKEN = ENV["GH_TOKEN"]
$commit = %x(git log --format=%H -1) # this gives the full commit hash, %h is the short
$user_email = ENV["USER_EMAIL"] # set through Travis
$user_name = ENV["USER_NAME"] # set through Travis


%x(git clone --quiet "https://#{ENV["USER_NAME"]}:#{ENV["GH_TOKEN"]}@github.com/#{$owner}/#{$repo}" #{ENV["HOME"]}/master > /dev/null)

Dir.chdir(ENV["HOME"] + "/master"){
    %x(git config user.email "#{ENV["USER_EMAIL"]}")
    %x(git config user.name "#{ENV["USER_NAME"]}")
    
    # build
    puts "initiating build..."
    exit_code = system "mvn clean compile assembly:single"
    if exit_code == false then
        puts "The build has failed!"
        exit false
    end
    %x(ls)
    %x(mvn clean compile assembly:single)
    %x(ls)

    begin
        puts "deleting previous release..."
        # delete release
        get = JSON.parse(RestClient.get "https://api.github.com/repos/#{$owner}/#{$repo}/releases/tags/#{$tag}?access_token=#{$GH_TOKEN}")
        RestClient.delete "https://api.github.com/repos/#{$owner}/#{$repo}/releases/#{get["id"]}?access_token=#{$GH_TOKEN}"
        
        # delete tag: deleting the GitHub release will not delete the tag on which the release is based
        %x(git tag -d #{$tag})
        %x(git push -q origin :refs/tags/#{$tag} > /dev/null)
        
        # creating a release seems to create a tag first...
        create_release
    rescue RestClient::ExceptionWithResponse => err
        case err.http_code
        when 404 # if there was no release with the given name, this is the first time this script is run in a repository
            create_release
        else
            raise
        end
    end
}
