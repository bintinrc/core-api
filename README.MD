<h1>Getting Started</h1>

recommended environment:
- gradle 5.4
- java 1.8

further read: [confluence](https://confluence.ninjavan.co/display/NVQA/D+-+Environment+Setup)

<h2>Run</h2>
from terminal:

```
gradle --no-daemon --continue \
  clean runCucumber allureReport \
  -Penvironment=local \
  -Ptags=@hello \
  -PdbHost="10.80.0.33" \
  -PdbPort=6333 \
  -PdbUser=qa_automation \
  -PdbPass=spMYtbidBKPaAV6BVxG0O9IfBzdMUtwA \
  -PdbEnvironment=qa \
  -PapiBaseUrl="https://api-qa.ninjavan.co" \
  -PsystemId=sg
```

from intellij gradle runner:
```
-Penvironment=qa-sg -Ptags=@ocv4 -PdbHost="10.80.0.33" -PdbPort=6333 -PdbUser=qa_automation -PdbPass=spMYtbidBKPaAV6BVxG0O9IfBzdMUtwA -PdbSystemId=sg -PdbEnvironment=qa -PapiBaseUrl="https://api-qa.ninjavan.co" -PapiSystemId="sg" -PsystemId=sg
```
further read: [confluence](https://confluence.ninjavan.co/display/NVQA/E+-+Run+Automation+Project)
