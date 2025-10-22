import { MainLayout } from "@/components/MainLayout/MainLayout";
import { SliceHero } from "@/components/SliceHero";
import { SliceWhy } from "@/components/SliceWhy";

export default function Home() {
  return (
    <MainLayout>
      <SliceHero />
      <SliceWhy />
    </MainLayout>
  );
}
