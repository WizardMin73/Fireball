Pod::Spec.new do |spec|
  spec.name = "Fireball"
  spec.version = "1.0.0"
  spec.summary = "Simple framework copyed from 'Result', not for real world use."
  spec.homepage = "https://github.com/WizardMin73/Fireball"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "M1N" => 'yoggsaron@outlook.com' }
  spec.social_media_url = ""

  spec.platform = :ios, "9.1"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/WizardMin73/Fireball.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "Fireball/**/*.{h,swift}"
end
