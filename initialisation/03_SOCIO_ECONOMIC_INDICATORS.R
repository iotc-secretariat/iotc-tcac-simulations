
# Read the data
CPC = data.table(read.xlsx("../cfg/CPC_CONFIGURATIONS.xlsx", sheet = "CPC", cols = 1:8))

CS_SOCIO_ECONOMICS = data.table(read.xlsx("../cfg/CPC_CONFIGURATIONS.xlsx", sheet = "COASTAL_STATE_SOCIO_ECONOMIC", cols = c(1:2, (8:9))))
