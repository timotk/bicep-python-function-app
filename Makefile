deploy:
	az deployment group create \
	 --resource-group ${RESOURCE_GROUP} \
	 --template-file main.bicep \
	 --parameters name=${NAME} location=${LOCATION}

what-if:
	az deployment group what-if \
	 --resource-group ${RESOURCE_GROUP} \
	 --template-file main.bicep \
	 --parameters name=${NAME} location=${LOCATION}

fa:
	func azure functionapp publish ${NAME} --build remote

test:
	curl -fsSL https://timobiceptest1.azurewebsites.net/api/example