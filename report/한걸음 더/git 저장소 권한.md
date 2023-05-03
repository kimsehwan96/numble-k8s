# Git 저장소 권한

`argocd` 의 레포지토리 시크릿을 추가해서 Private 저장소를 접근합니다. 

이 때 `argocd.argoproj.io/secret-type` 레이블을 해당 k8s secret에 달아서 생성하면 됩니다. 

ref : https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/

## GitHub App Credential

여러 방식중에 GitHub App Credential 방법을 소개하자면 

https://docs.github.com/en/developers/apps/about-apps#about-github-apps

위를 참고하여 Github app 을 생성하고, `github app id`, `github app installation id`, `github-app-private-key` 등을 발급받아서 사용 가능하며, 이 때 아래와 같이 secret 을 생성하면 된다. (외부 secret 저장소를 사용가능한 경우 사용하는게 좋을 것 같다.)

```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: my-private-repo-secret
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  githubAppID: AppID
  githubAppInstallationID: InstallationID
  githubAppPrivateKey: PrivateKey
  type: git
  url: url
```