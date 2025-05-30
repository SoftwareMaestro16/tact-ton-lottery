import { toNano } from '@ton/core';
import { Lottery } from '../wrappers/Lottery';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const lottery = provider.open(await Lottery.fromInit(
        toNano("0.6"),
        toNano("0.125"),
        toNano("1.25")
    ));

    await lottery.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: "ChangeConfig",
            bid: toNano("0.8"),
            minPrize: toNano("0.525"),
            maxPrize: toNano("2.25")
        },
        // {
        //     $$type: 'Withdraw',
        //     amount: toNano("1.249")
        // }
    );

    await provider.waitForDeploy(lottery.address);

    // run methods on `lottery`
}
