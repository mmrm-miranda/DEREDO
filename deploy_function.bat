@echo off
echo Desplegando Cloud Function...
gcloud functions deploy deredo-api --gen2 --runtime=python312 --region=us-central1 --source=cloud_function --entry-point=api --trigger-http --allow-unauthenticated --env-vars-file=cloud_function\env.yaml
echo Listo!
pause
