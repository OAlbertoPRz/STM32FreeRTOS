#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "uart_app.h"
#include "stm32f4xx_hal_rcc.h"

// Functions
static void SystemClock_Conf(void);
static HAL_StatusTypeDef USART_Conf(USART_HandleTypeDef* husart_Template);
static void GPIO_In_Conf(GPIO_TypeDef *GPIOx, uint16_t GPIOx_pin);
static void GPIO_Out_Conf(GPIO_TypeDef *GPIOx, uint16_t GPIOx_pin);
static void GPIO_AF_Conf(GPIO_TypeDef *GPIOx);

// Variables
USART_HandleTypeDef husart3;
char status[]= "Succesfully configurated";
char message[] = "Hello!\n\n";

int main(){
    // Initializing HAL
    HAL_Init();
    
    // Enabling Peripherals
    __GPIOC_CLK_ENABLE();
    __USART3_CLK_ENABLE();
    __GPIOB_CLK_ENABLE();    
    __GPIOA_CLK_ENABLE();

    // Setting the GPIOB pins
    GPIO_In_Conf(GPIOB, PUSHB);

    // Setting the GPIOA pins
    GPIO_Out_Conf(GPIOA, USER_LED);
    GPIO_Out_Conf(GPIOA, RED_LED);

    // Setting the GPIOC (10 and 11) as Alterante function USART
    GPIO_AF_Conf(GPIOC);

    // Setting the UART4 pins
    if(USART_Conf(&husart3))
    {
        // Toggle led indicator
        for (int i=4; i>0; i--)
        {
            HAL_GPIO_TogglePin(GPIOA, USER_LED);
            HAL_Delay(500);
        }
    }
    else
    {
        HAL_GPIO_TogglePin(GPIOA, RED_LED);
        // Send a message
        HAL_UART_Transmit(&husart3, (uint8_t*)status, strlen(status), HAL_MAX_DELAY);
    }
     
    while(1)
    {
        if(HAL_UART_Transmit(&husart3, (uint8_t*)message, strlen(message), HAL_MAX_DELAY) == HAL_OK)
        {
            HAL_GPIO_TogglePin(GPIOA, RED_LED);
        }
        HAL_Delay(1000);
    }
    
    return 0;
}

static HAL_StatusTypeDef USART_Conf(USART_HandleTypeDef* husart_Template){
    
    husart_Template->Instance = USART3;
    husart_Template->Init.BaudRate = 9600;
    husart_Template->Init.WordLength = USART_WORDLENGTH_8B;
    husart_Template->Init.StopBits = USART_STOPBITS_1;
    husart_Template->Init.Parity = USART_PARITY_NONE;
    husart_Template->Init.Mode = USART_MODE_TX_RX;
    husart_Template->Init.CLKPolarity = USART_CLOCK_DISABLED;
    husart_Template->Init.CLKPhase = USART_CLOCK_DISABLED;
    husart_Template->Init.CLKLastBit = USART_CLOCK_DISABLED;
    //husart_Template->Init.HwFlowCtl = UART_HWCONTROL_NONE;
    //husart_Template->Init.OverSampling = UART_OVERSAMPLING_16;

    return (HAL_UART_Init(husart_Template));
}


static void GPIO_In_Conf(GPIO_TypeDef *GPIOx, uint16_t GPIOx_pin)
{
    GPIO_InitTypeDef GPIO_TemplateStruct;

    HAL_GPIO_WritePin(GPIOx, GPIOx_pin, GPIO_PIN_SET);

    GPIO_TemplateStruct.Pin = GPIOx_pin;
    GPIO_TemplateStruct.Mode = GPIO_MODE_INPUT;
    GPIO_TemplateStruct.Speed = GPIO_SPEED_FREQ_LOW;
    GPIO_TemplateStruct.Pull = GPIO_NOPULL;

    HAL_GPIO_Init(GPIOx, &GPIO_TemplateStruct);
}


static void GPIO_Out_Conf(GPIO_TypeDef *GPIOx, uint16_t GPIOx_pin)
{
    GPIO_InitTypeDef GPIO_TemplateStruct;

    HAL_GPIO_WritePin(GPIOx, GPIOx_pin, GPIO_PIN_RESET);

    GPIO_TemplateStruct.Pin = GPIOx_pin;
    GPIO_TemplateStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_TemplateStruct.Speed = GPIO_SPEED_FREQ_LOW;
    GPIO_TemplateStruct.Pull = GPIO_NOPULL;

    HAL_GPIO_Init(GPIOx, &GPIO_TemplateStruct);
}


static void GPIO_AF_Conf(GPIO_TypeDef *GPIOx)
{
    GPIO_InitTypeDef GPIO_TemplateStruct;

    GPIO_TemplateStruct.Pin = TX_PIN;
    GPIO_TemplateStruct.Mode = GPIO_MODE_AF_PP;
    GPIO_TemplateStruct.Speed = GPIO_SPEED_FREQ_HIGH;
    GPIO_TemplateStruct.Alternate = GPIO_AF7_USART3;

    // TX Pin: PC10
    HAL_GPIO_Init(GPIOx, &GPIO_TemplateStruct);

    // Setting the RX Pin: PC11
    GPIO_TemplateStruct.Pin = RX_PIN;
    HAL_GPIO_Init(GPIOx, &GPIO_TemplateStruct);
}


static void SystemClock_Conf(void){
    RCC_ClkInitTypeDef RCC_ClkInitStruct;
    RCC_OscInitTypeDef RCC_OscInitStruct;

    /* Enable Power Control clock */
    __HAL_RCC_PWR_CLK_ENABLE();

    /* The voltage scaling allows optimizing the power consumption when the device
        is clocked below the maximum system frequency, to update the voltage
        scaling value regarding system frequency refer to product datasheet.  */
    __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

    /* Enable HSI Oscillator and activate PLL with HSI as source */
    RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
    RCC_OscInitStruct.HSIState = RCC_HSI_ON;
    RCC_OscInitStruct.HSICalibrationValue = 0x10;
    RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
    RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
    RCC_OscInitStruct.PLL.PLLM = 16;
    RCC_OscInitStruct.PLL.PLLN = 200;
    RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
    RCC_OscInitStruct.PLL.PLLQ = 7;
    RCC_OscInitStruct.PLL.PLLR = 2;

    HAL_RCC_OscConfig(&RCC_OscInitStruct);

    /* Select PLL as system clock source and configure the HCLK, PCLK1 and
        PCLK2 clocks dividers */
    RCC_ClkInitStruct.ClockType = (RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_HCLK |
                                   RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2);
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
    HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5);
}