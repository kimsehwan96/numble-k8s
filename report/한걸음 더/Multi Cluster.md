# Multi Cluister

우선 manifests (yaml) 파일(i.e helm chart) 들만 관리하는 레포지토리라고 생각 했을 때. 

하나의 레포지토리에서 여러 클러스터에 대한 manifests 관리를 하기 위해서는 kustomize 와 같은 도구를 사용해서, 공통으로 사용할 manifests, 그리고 스테이지(형상)별로 다른 값들을 분리해서 overlay 형태로 관리하는게 권장됩니다.

```
.
├── base
│   ├── config.yaml
│   └── kustomization.yaml
└── overlays
    ├── development
    │   ├── config-patch.yaml
    │   └── kustomization.yaml
    ├── production
    │   ├── config-patch.yaml
    │   └── kustomization.yaml
    └── staging
        ├── config-patch.yaml
        └── kustomization.yaml
```

위와 같이 base (공용)으로 사용할 데이터를 포함하여 환경/클러스터별로 다른 설정값들이나 환경변수 같은 것들을 분리하여서 관리하면 되며, 이 때 kustomize 도구를 사용하면 좋습니다.