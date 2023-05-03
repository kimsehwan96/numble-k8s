# Persistence

Prometheus 및 Grafana 의 파드가 재시작 되더라도 데이터가 유지되게 하기 위해서는. 

`PersistenceVolumeClaim`을 통해 `PersistenceVolume`을 생성하고. (Ncloud 등 클라우드 공급자) 이 `PersistenceVolume`을 파드와 마운트하여 파드가 재시작 되더라도 데이터가 휘발되는 것이 아닌, `PersistenceVoluem` 에 저장이 되게 됩니다. (적절하게 볼륨을 파드에 잘 마운트 했다는 것 기준)

따라서 helmChart 에서 특정 서비스들이 pvc 를 생성하는 템플릿이 있고, 해당하는 value를 반영 할 수 있다면 helmChart 를 통해 생성하고. 이 때에는 보통 volumeClaimTemplate 과 같은 명칭으로 생성하게 하여서 `persistenceVolumeClaim`을 어떻게 할 것인지. (스토리지 클래스, 용량 등)을 지정 할 수 있습니다. 

