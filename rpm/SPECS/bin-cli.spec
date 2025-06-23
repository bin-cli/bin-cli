Name:           bin-cli
Summary:        A simple task/script runner for any programming language
URL:            https://github.com/bin-cli/bin-cli
License:        MIT
Version:        %{version}
Release:        1%{?dist}
BuildArch:      noarch
Requires:       bash

%description
Bin CLI is a simple task runner, designed to be used in code repositories, with
scripts written in any programming language.

It automatically searches in parent directories, so you can run scripts from
anywhere in the project tree. It also supports aliases, unique prefix matching
and tab completion, reducing the amount you need to type.

Collaborators / contributors who choose not to install Bin can run the scripts
directly, so you can enjoy the benefits without adding a hard dependency or
extra barrier to entry.

%build
bin/generate/bin "%{version}"
bin/generate/completion
bin/generate/man "%{version}"
bin/generate/man-html "%{version}"
bin/generate/readme-html

%install
install -Dm 0755 dist/bin                   %{buildroot}%{_bindir}/bin
install -Dm 0644 dist/bin.bash-completion   %{buildroot}%{_datadir}/bash-completion/completions/bin
install -Dm 0644 dist/bin.1.gz              %{buildroot}%{_mandir}/man1/bin.1.gz
install -Dm 0644 dist/readme.css            %{buildroot}%{_docdir}/bin-cli/readme.css
install -Dm 0644 dist/readme.html           %{buildroot}%{_docdir}/bin-cli/index.html

%files
%{_bindir}/bin
%{_datadir}/bash-completion/completions/bin
%{_mandir}/man1/bin.1.gz
%dir %{_docdir}/bin-cli
%doc %{_docdir}/bin-cli/readme.css
%doc %{_docdir}/bin-cli/index.html
