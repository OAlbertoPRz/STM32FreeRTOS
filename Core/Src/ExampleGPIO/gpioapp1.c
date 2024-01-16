#include <stdio.h>
#include <stdint.h>
#include "gpioapp1.h"
#include "stm32f4xx_hal_rcc.h"

// Functions
static void SystemClock_Configuration(void);
static void GPIO_Out_Init(GPIO_TypeDef *GPIOx, uint16_t GPIOx_pin);
static void GPIO_Input_Init(GPIO_TypeDef *GPIOx, uint16_t GPIOx_pin);
static void SemaphoreApp(void);
int isButtonPressed(void);

int main(void)
{
    // HAL initializer
    HAL_Init();

    // Setting the SystemClock
    SystemClock_Configuration();

    // Enabling the GPIOA Peripherals
    __HAL_RCC_GPIOA_CLK_ENABLE();

    // Enabling the GPIOB Peripherals
    __HAL_RCC_GPIOB_CLK_ENABLE();

    // Setting the pin 0, pin 1, pin 4 and pin 5 of the GPIOA as outputs
    GPIO_Out_Init(GPIOA, LED_GREEN);
    GPIO_Out_Init(GPIOA, LED_YELLOW);
    GPIO_Out_Init(GPIOA, LED_RED);
    GPIO_Out_Init(GPIOA, LED1);

    // Setting the pin 0 of port B
    GPIO_Input_Init(GPIOB, PUSHB);

    uint8_t AppSelector = 0;
    // Infinite loop
    while (1)
    {
        if (isButtonPressed())
        {
            while (isButtonPressed());
            if(AppSelector == 0) AppSelector=1;
            else AppSelector=0;
        }
        if (AppSelector == 1)
        {
            SemaphoreApp();
        }
        else 
        {
            HAL_GPIO_WritePin(GPIOA, LED_GREEN, GPIO_PIN_SET);
            HAL_GPIO_WritePin(GPIOA, LED_YELLOW, GPIO_PIN_SET);
            HAL_GPIO_WritePin(GPIOA, LED_RED, GPIO_PIN_SET);
            HAL_Delay(2000);
            HAL_GPIO_WritePin(GPIOA, LED_GREEN, GPIO_PIN_RESET);
            HAL_GPIO_WritePin(GPIOA, LED_YELLOW, GPIO_PIN_RESET);
            HAL_GPIO_WritePin(GPIOA, LED_RED, GPIO_PIN_RESET);
            HAL_Delay(2000);
        }
    }
    return 0;
}

int isButtonPressed(void)
{
    if (HAL_GPIO_ReadPin(GPIOB, PUSHB) == GPIO_PIN_SET)
    {
        HAL_Delay(10); // Add a small delay for debouncing
        if (HAL_GPIO_ReadPin(GPIOB, PUSHB) == GPIO_PIN_SET)
        {
            return 1;
        }
    }
    return 0;
}

static void SemaphoreApp(void)
{
    HAL_GPIO_TogglePin(GPIOA, LED1);
    HAL_GPIO_TogglePin(GPIOA, LED_GREEN);
    HAL_Delay(2000); // Delay
    HAL_GPIO_TogglePin(GPIOA, LED_GREEN);
    HAL_GPIO_TogglePin(GPIOA, LED_YELLOW);
    HAL_Delay(500); // Delay
    HAL_GPIO_TogglePin(GPIOA, LED_YELLOW);
    HAL_GPIO_TogglePin(GPIOA, LED_RED);
    HAL_Delay(4000); // Delay
    HAL_GPIO_TogglePin(GPIOA, LED_RED);
}

static void GPIO_Out_Init(GPIO_TypeDef *GPIOx, uint16_t GPIOx_pin)
{

    GPIO_InitTypeDef GPIO_TemplateStruct;

    HAL_GPIO_WritePin(GPIOx, GPIOx_pin, GPIO_PIN_RESET);

    GPIO_TemplateStruct.Pin = GPIOx_pin;
    GPIO_TemplateStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_TemplateStruct.Speed = GPIO_SPEED_FREQ_LOW;
    GPIO_TemplateStruct.Pull = GPIO_NOPULL;

    HAL_GPIO_Init(GPIOx, &GPIO_TemplateStruct);
}

static void GPIO_Input_Init(GPIO_TypeDef *GPIOx, uint16_t GPIOx_pin)
{

    GPIO_InitTypeDef GPIO_TemplateStruct;

    HAL_GPIO_WritePin(GPIOx, GPIOx_pin, GPIO_PIN_SET);

    GPIO_TemplateStruct.Pin = GPIOx_pin;
    GPIO_TemplateStruct.Mode = GPIO_MODE_INPUT;
    GPIO_TemplateStruct.Speed = GPIO_SPEED_FREQ_LOW;
    GPIO_TemplateStruct.Pull = GPIO_NOPULL;

    HAL_GPIO_Init(GPIOx, &GPIO_TemplateStruct);
}

static void SystemClock_Configuration(void)
{
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